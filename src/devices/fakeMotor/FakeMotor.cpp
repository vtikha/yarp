/*
 * Copyright (C) 2006-2020 Istituto Italiano di Tecnologia (IIT)
 * Copyright (C) 2006-2010 RobotCub Consortium
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms of the
 * BSD-3-Clause license. See the accompanying LICENSE file for details.
 */

#include "FakeMotor.h"

YARP_LOG_COMPONENT(FAKEMOTOR, "yarp.device.fakeMotor")

void FakeMotor::update()
{
    if (posMode) {
        return;
    }

    double now = yarp::os::Time::now();
    if (last < 0) {
        last = now;
    }
    double dt = now - last;
    for (int i=0; i<njoints; i++) {
        pos[i] += vel[i] * dt;
    }
    last = now;
}


bool TestMotor::open(yarp::os::Searchable& config)
{
    yCWarning(FAKEMOTOR, "'test_motor' was renamed 'fakeMotor'. The old name is still supported for compatibility, but it will be deprecated and removed in a future release. Please update your scripts");
    return FakeMotor::open(config);
}
