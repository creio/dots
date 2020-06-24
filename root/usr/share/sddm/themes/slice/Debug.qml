import QtQuick 2.7
import SddmComponents 2.0

Item
{
    readonly property bool active: bool(config.debug)

    function debugbool(config_value, real_property)
    {
        return (active && bool(config_value)) || real_property;
    }

    function debugnum(config_value, real_property)
    {
        if (config_value === null || config_value === undefined)
            return real_property;

        return active ? Number(config_value).valueOf() : real_property;
    }

    function debugstr(config_value, real_property)
    {
        if (config_value === null || config_value === undefined)
            return real_property;

        return active ? config_value : real_property;
    }

    readonly property bool canPowerOff: debugbool(config.debug_can_power_off, sddm.canPowerOff)
    readonly property bool canReboot: debugbool(config.debug_can_reboot, sddm.canReboot)
    readonly property bool canSuspend: debugbool(config.debug_can_suspend, sddm.canSuspend)
    readonly property bool canHibernate: debugbool(config.debug_can_hibernate, sddm.canHibernate)
    readonly property bool canHybridSleep: debugbool(config.debug_can_hybrid_sleep, sddm.canHybridSleep)
    readonly property bool loginError: debugbool(config.debug_login_error, false)
    readonly property int loginTimeout: debugnum(config.debug_login_timeout, 0)
    readonly property string hostName: debugstr(config.debug_hostname, sddm.hostName)

}