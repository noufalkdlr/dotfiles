pragma Singleton
import QtQuick

QtObject {
    id: root

    property var activePopup: null

    function request(popup) {
        if (root.activePopup && root.activePopup !== popup) {
            root.activePopup.visible = false
        }
        root.activePopup = popup
    }

    function closeIfActive(popup) {
        if (root.activePopup === popup) {
            root.activePopup = null
        }
    }
}
