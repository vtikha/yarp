/*
 * Copyright (C) 2006-2020 Istituto Italiano di Tecnologia (IIT)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0

StatusBar {
    id: bar
    height: 20*(3+pixelValPresent)
    property string avgFps: "0.0"
    property string minFps: "0.0"
    property string maxFps: "0.0"
    property string portSizeX: "0"
    property string portSizeY: "0"

    property string displayAvgFps: "0.0"
    property string displayMinFps: "0.0"
    property string displayMaxFps: "0.0"
    property string displaySizeX: "0"
    property string displaySizeY: "0"

    property string name: "/name"

    property string pixelValStr: "#00000000"
    property string pixelXStr: "0"
    property string pixelYStr: "0"
    property color pixelValCol: "#00000000"
    property int pixelValPresent: 0

    function setName(name){
        bar.name = name
    }
    /*! \brief Determines whether or not the information about the currently selected pixel have to be visible
     *  \param flag Boolean: If true the information about the currently selected pixel are visible
     */
    function setPixelValVisibility(flag){
        pixelValPresent = flag ? 1 : 0;
    }

    /*! \brief Sets the pixelValStr and pixelValCol values
     *  \param hexstring String: The hexadecimal string representing the selected pixel color
     */
    function setPixelVal(hexstring){
        pixelValStr = hexstring;
        pixelValCol = hexstring !== "Invalid" ? pixelValCol = hexstring : "#00000000";
    }

    ColumnLayout{
        anchors.fill: parent

        Label{
            id: fps
            text: "Port: " + bar.avgFps +
                  " (min:" + bar.minFps +
                  " max:" + bar.maxFps +") fps; " +
                  "(size: " + bar.portSizeX + "x" + bar.portSizeY + ")"
            fontSizeMode: Text.HorizontalFit
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label{
            id: displayFps
            text: "Display: " + bar.displayAvgFps +
                  " (min:" + bar.displayMinFps +
                  " max:" + bar.displayMaxFps +") fps; "+
                  "(size: " + bar.displaySizeX + "x" + bar.displaySizeY + ")"
            fontSizeMode: Text.HorizontalFit
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        RowLayout{
            id: pixelValRowLO
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: pixelValPresent==1

            Label{
                id: pixelValLabel
                text: "Pixel ("+bar.pixelXStr+", "+bar.pixelYStr+") = "+bar.pixelValStr
                fontSizeMode: Text.VerticalFit
                Layout.fillHeight: true
            }

            Rectangle{
                id: pixelValRect
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumWidth: height
                Layout.maximumWidth: height
                color: pixelValCol
            }

            Item{
                id: pixelValSpacer
                Layout.fillWidth: true
                Layout.minimumWidth: pixelValLabel
                Layout.maximumWidth: pixelValLabel
            }
        }

        Label{
            id: name
            text: bar.name
            fontSizeMode: Text.VerticalFit
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }


}
