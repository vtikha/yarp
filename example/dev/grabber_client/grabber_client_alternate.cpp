/*
 * Copyright (C) 2006-2020 Istituto Italiano di Tecnologia (IIT)
 * Copyright (C) 2006-2010 RobotCub Consortium
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms of the
 * BSD-3-Clause license. See the accompanying LICENSE file for details.
 */

#include <yarp/os/BufferedPort.h>
#include <yarp/os/Network.h>

#include <yarp/sig/Image.h>

#include <cstdio>

using yarp::os::BufferedPort;
using yarp::os::Network;
using yarp::sig::ImageOf;
using yarp::sig::PixelRgb;

/*
 * Read an image from a remote source using the "port" view of
 * camera-like sources.
 *
 * Remote source could be, for example:
 *   yarpdev --device fakeFrameGrabber --name /fakey
 */
int main(int argc, char* argv[])
{
    YARP_UNUSED(argc);
    YARP_UNUSED(argv);

    Network yarp;

    std::string local = "/client";
    std::string remote = "/fakey";

    BufferedPort<ImageOf<PixelRgb>> port;
    port.open(local);
    Network::connect(remote, local);
    ImageOf<PixelRgb>* img = port.read();
    if (img != nullptr) {
        printf("Got a %zux%zu image\n", img->width(), img->height());
    }
    port.close();

    return 0;
}
