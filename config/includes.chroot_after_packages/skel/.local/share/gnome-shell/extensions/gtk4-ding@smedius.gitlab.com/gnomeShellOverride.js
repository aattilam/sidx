/* Gnome Shell Override
 *
 * Copyright (C) 2021 - 2023 Sundeep Mediratta (smedius@gmail.com)
 * Copyright (C) 2020 Sergio Costas (rastersoft@gmail.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/* exported GnomeShellOverride */

const { Meta, Clutter, GLib, Shell } = imports.gi;
const Main = imports.ui.main;
const ExtensionUtils = imports.misc.extensionUtils;
const { ExtensionState } = ExtensionUtils;
const ExtensionManager = Main.extensionManager;
const Config = imports.misc.config;

var WorkspaceAnimation = null;
try {
    WorkspaceAnimation = imports.ui.workspaceAnimation;
} catch (err) {
    log('Workspace Animation does not exist');
}

var WindowManager = null;
try {
    WindowManager = imports.ui.windowManager;
} catch (err) {
    log('WindowManager does not exist');
}

const GnomeShellVersion = parseInt(Config.PACKAGE_VERSION.split('.')[0]);
const autoMoveWindowsuuid = 'auto-move-windows@gnome-shell-extensions.gcampax.github.com';

var replaceData = {};
var workSpaceSwitchTimeoutID = null;

/*
* This class overrides methods in the Gnome Shell. The new methods
* need to be defined below the class as seperate functions.
* The old methods that are overriden can be accesed by relpacedata.old_'name-of-replaced-method'
* in the new functions
*/


var GnomeShellOverride = class {
    constructor() {
        this._isX11 = !Meta.is_wayland_compositor();
    }

    enable() {
        // Prevent window flicker as the DING window moves to the new workspace.
        if (WorkspaceAnimation) {
            this.replaceMethod(WorkspaceAnimation.WorkspaceGroup, '_shouldShowWindow', newShouldShowWindow);
            this.replaceMethod(WorkspaceAnimation.WorkspaceAnimationController, '_finishWorkspaceSwitch', newFinishWorkspaceSwitch);
        }
        // Prevent the unlimited workspaces by not acccounting for the DING window to define empty workspace
        if (GnomeShellVersion <= 44) {
            this._prevCheckWorkspaces = null;
            this._checkWorkspacesID = ExtensionManager.connect('extension-state-changed', (_obj, extension) => {
                if (!extension)
                    return;
                if (extension.uuid === autoMoveWindowsuuid)
                    this._replaceCheckWorkspaces();
            });
            this._replaceCheckWorkspaces();
        }
    }

    // restore external methods only if have been intercepted

    disable() {
        if (workSpaceSwitchTimeoutID) {
            GLib.Source.remove(workSpaceSwitchTimeoutID);
            workSpaceSwitchTimeoutID = 0;
        }

        if (this._checkWorkspacesId)
            ExtensionManager.disconnect(this._checkWorkspacesID);
        this._checkWorkspacesID = 0;

        this._disableCheckWorkSpaces();
        for (let value of Object.values(replaceData)) {
            if (value[0])
                value[1].prototype[value[2]] = value[0];
        }
        replaceData = {};
    }


    restoreMethod(oldMethodName) {
        let value = replaceData[oldMethodName];
        if (value) {
            if (value[0])
                value[1].prototype[value[2]] = value[0];
        }
        delete replaceData[oldMethodName];
    }

    _deleteMethod(oldMethodName) {
        delete replaceData[oldMethodName];
    }

    /**
     * Replaces a method in a class with our own method, and stores the original
     * one in 'replaceData' using 'old_XXXX' (being XXXX the name of the original method),
     * or 'old_classId_XXXX' if 'classId' is defined. This is done this way for the
     * case that two methods with the same name must be replaced in two different
     * classes
     *
     * @param {class} className The class where to replace the method
     * @param {string} methodName The method to replace
     * @param {Function} functionToCall The function to call as the replaced method
     * @param {string} [classId] an extra ID to identify the stored method when two
     *                           methods with the same name are replaced in
     *                           two different classes
     */

    replaceMethod(className, methodName, functionToCall, classId = null) {
        if (classId)
            replaceData[`old_${classId}_${methodName}`] = [className.prototype[methodName], className, methodName, classId];
        else
            replaceData[`old_${methodName}`] = [className.prototype[methodName], className, methodName];

        className.prototype[methodName] = functionToCall;
    }

    _replaceCheckWorkspaces() {
        let extensionLoaded = ExtensionManager.getUuids().includes(autoMoveWindowsuuid);
        let extensionEnabled = checkEnabled(autoMoveWindowsuuid);
        if (extensionLoaded && extensionEnabled) {
            this._prevCheckWorkspaces = Main.wm._workspaceTracker._checkWorkspaces;
            Main.wm._workspaceTracker._checkWorkspaces = newAutoMoveCheckWorkspaces();
        } else {
            this._prevCheckWorkspaces = Main.wm._workspaceTracker._checkWorkspaces;
            Main.wm._workspaceTracker._checkWorkspaces = newCheckWorkspaces;
        }
    }

    _disableCheckWorkSpaces() {
        if (this._prevCheckWorkspaces)
            Main.wm._workspaceTracker._checkWorkspaces = this._prevCheckWorkspaces;
        this._prevCheckWorkspaces = null;
    }
};


/**
 * New Functions used to replace the gnome shell functions are defined below.
 */

/**
 * Method replacement for should_show_window
 * Adds the desktop window to the background if it is not on that workspace, removes from _syncstack
 * Therefore while switching workspaces with gestures, it appears the icons are already there.
 *
 * @param {Meta.Window} window the window
 */
function newShouldShowWindow(window) {
    if (window.customJS_ding && this._workspace) {
        if (!this.dingClone) {
            const geometry = global.display.get_monitor_geometry(this._monitor.index);
            const [intersects] = window.get_frame_rect().intersect(geometry);
            if (intersects && this._background) {
                this.dingClone = new Clutter.Clone({
                    source: window.actor,
                    x: window.actor.x - this._monitor.x,
                    y: window.actor.y - this._monitor.y,
                });
                this._background.add_child(this.dingClone);
            }
        }
        return false;
    }
    return replaceData.old__shouldShowWindow[0].apply(this, [window]);
}

/**
 * Method replacement for finishWorkspaceSwitch
 * Adds a delay before destroying the moving window
 * To give time for the DING window to move to the new Workspace behind the moving window.
 * To prevent flickering of icons.
 *
 * @param {object} switchData the original switchData for the function
 */
function newFinishWorkspaceSwitch(switchData) {
    let movingWindow = this.movingWindow;
    let mymonitorGroup = switchData.monitors;
    let dummyMonitor = Clutter.Actor.new();
    switchData.monitors = [dummyMonitor];

    replaceData.old__finishWorkspaceSwitch[0].apply(this, [switchData]);

    workSpaceSwitchTimeoutID = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => {
        mymonitorGroup.forEach(m => m.destroy());
        movingWindow = null;
        workSpaceSwitchTimeoutID = null;
        return false;
    });
}

/**
 * Method replacement for checkWorkspaces if auto-move-windows is enabled
 * Makes sure that the DING window does not count in decision to make new Workspace
 *
 */
function newAutoMoveCheckWorkspaces() {
    return function () {
        const keepAliveWorkspaces = [];
        let foundNonEmpty = false;
        for (let i = this._workspaces.length - 1; i >= 0; i--) {
            if (!foundNonEmpty) {
                foundNonEmpty = this._workspaces[i].list_windows().some(
                    w => !(w.is_on_all_workspaces() || w.customJS_ding));
            } else if (!this._workspaces[i]._keepAliveId) {
                keepAliveWorkspaces.push(this._workspaces[i]);
            }
        }

        // make sure the original method only removes empty workspaces at the end
        keepAliveWorkspaces.forEach(ws => (ws._keepAliveId = 1));
        newCheckWorkspaces.call(this);
        keepAliveWorkspaces.forEach(ws => delete ws._keepAliveId);

        return false;
    };
}

/**
 * Method replacement for checkWorkspaces
 * Makes sure that the DING window does not count in decision to make new Workspace
 *
 */
function newCheckWorkspaces() {
    let MIN_NUM_WORKSPACES = 2;
    let workspaceManager = global.workspace_manager;
    let i;
    let emptyWorkspaces = [];

    if (!Meta.prefs_get_dynamic_workspaces()) {
        this._checkWorkspacesId = 0;
        return false;
    }

    // Update workspaces only if Dynamic Workspace Management has not been paused by some other function
    if (this._pauseWorkspaceCheck)
        return true;

    for (i = 0; i < this._workspaces.length; i++) {
        let lastRemoved = this._workspaces[i]._lastRemovedWindow;
        if ((lastRemoved &&
             (lastRemoved.get_window_type() == Meta.WindowType.SPLASHSCREEN ||
              lastRemoved.get_window_type() == Meta.WindowType.DIALOG ||
              lastRemoved.get_window_type() == Meta.WindowType.MODAL_DIALOG)) ||
            this._workspaces[i]._keepAliveId)
            emptyWorkspaces[i] = false;
        else
            emptyWorkspaces[i] = true;
    }

    let sequences = Shell.WindowTracker.get_default().get_startup_sequences();
    for (i = 0; i < sequences.length; i++) {
        let index = sequences[i].get_workspace();
        if (index >= 0 && index <= workspaceManager.n_workspaces)
            emptyWorkspaces[index] = false;
    }

    let windows = global.get_window_actors();
    for (i = 0; i < windows.length; i++) {
        let actor = windows[i];
        let win = actor.get_meta_window();
        // Don't use the DING window to decide if workspace is empty
        if (win.is_on_all_workspaces() || win.customJS_ding)
            continue;

        let workspaceIndex = win.get_workspace().index();
        emptyWorkspaces[workspaceIndex] = false;
    }

    // If we don't have an empty workspace at the end, add one
    if (!emptyWorkspaces[emptyWorkspaces.length - 1]) {
        workspaceManager.append_new_workspace(false, global.get_current_time());
        emptyWorkspaces.push(true);
    }

    // Enforce minimum number of workspaces
    while (emptyWorkspaces.length < MIN_NUM_WORKSPACES) {
        workspaceManager.append_new_workspace(false, global.get_current_time());
        emptyWorkspaces.push(true);
    }

    let lastIndex = emptyWorkspaces.length - 1;
    let lastEmptyIndex = emptyWorkspaces.lastIndexOf(false) + 1;
    let activeWorkspaceIndex = workspaceManager.get_active_workspace_index();
    emptyWorkspaces[activeWorkspaceIndex] = false;

    // Delete empty workspaces except for the last one; do it from the end
    // to avoid index changes
    for (i = lastIndex; i >= 0; i--) {
        if (workspaceManager.n_workspaces === MIN_NUM_WORKSPACES)
            break;
        if (emptyWorkspaces[i] && i != lastEmptyIndex)
            workspaceManager.remove_workspace(this._workspaces[i], global.get_current_time());
    }

    this._checkWorkspacesId = 0;
    return false;
}

/**
 * Checks if extension uuid exists, is loaded and enabled
 * Useful in ordering extensions, so we can load and override Gnome Shell as necessary
 *
 * @param {string} uuid the extension uuid
 * @returns {bool} if the extension is enabled
 */
function checkEnabled(uuid) {
    let extension = ExtensionManager.lookup(uuid);
    if (!extension)
        return false;
    if (extension.state !== ExtensionState.ENABLED)
        return false;
    else
        return true;
}

