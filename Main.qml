import QtQuick 2.0
import Ubuntu.Components 1.1

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "podcast.liu-xiao-guo"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(60)
    height: units.gu(85)

    GenericPodcastApp {
        name: "Bad Voltage"
        squareLogo: "images/logo.jpg"
        author: "Stuart Langridge, Jono Bacon, Jeremy Garcia, and Bryan Lunduke"
        category: "Technology"
        feed: "http://www.badvoltage.org/feed/ogg/"
        description: "Every two weeks Bad Voltage delivers an amusing take on technology, Open Source, politics, music, and anything else we think is interesting."
    }
}

