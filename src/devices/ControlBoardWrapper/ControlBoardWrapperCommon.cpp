/*
 * Copyright (C) 2006-2020 Istituto Italiano di Tecnologia (IIT)
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms of the
 * BSD-3-Clause license. See the accompanying LICENSE file for details.
 */

#include "ControlBoardWrapperCommon.h"

#include "ControlBoardWrapperLogComponent.h"


bool ControlBoardWrapperCommon::getAxes(int* ax)
{
    *ax = controlledJoints;
    return true;
}


bool ControlBoardWrapperCommon::setRefAcceleration(int j, double acc)
{
    int off;
    try {
        off = device.lut.at(j).offset;
    } catch (...) {
        yCError(CONTROLBOARDWRAPPER, "Joint number %d out of bound [0-%d] for part %s", j, controlledJoints, partName.c_str());
        return false;
    }
    int subIndex = device.lut[j].deviceEntry;

    SubDevice* p = device.getSubdevice(subIndex);

    if (!p) {
        return false;
    }

    if (p->pos) {
        return p->pos->setRefAcceleration(off + p->base, acc);
    }
    return false;
}


bool ControlBoardWrapperCommon::setRefAccelerations(const double* accs)
{
    bool ret = true;
    int j_wrap = 0; // index of the joint from the wrapper side (useful if wrapper joins 2 subdevices)

    // for all subdevices
    for (unsigned int subDev_idx = 0; subDev_idx < device.subdevices.size(); subDev_idx++) {
        SubDevice* p = device.getSubdevice(subDev_idx);

        if (!p) {
            return false;
        }

        int wrapped_joints = (p->top - p->base) + 1;
        int* joints = new int[wrapped_joints]; // to be defined once and for all?

        if (p->pos) {
            // verione comandi su subset di giunti
            for (int j_dev = 0; j_dev < wrapped_joints; j_dev++) {
                joints[j_dev] = p->base + j_dev;
            }

            ret = ret && p->pos->setRefAccelerations(wrapped_joints, joints, &accs[j_wrap]);
            j_wrap += wrapped_joints;
        } else {
            ret = false;
        }

        if (joints != nullptr) {
            delete[] joints;
            joints = nullptr;
        }
    }

    return ret;
}


bool ControlBoardWrapperCommon::setRefAccelerations(const int n_joints, const int* joints, const double* accs)
{
    bool ret = true;

    rpcDataMutex.lock();
    //Reset subdev_jointsVectorLen vector
    memset(rpcData.subdev_jointsVectorLen, 0x00, sizeof(int) * rpcData.deviceNum);

    // Create a map of joints for each subDevice
    int subIndex = 0;
    for (int j = 0; j < n_joints; j++) {
        subIndex = device.lut[joints[j]].deviceEntry;
        rpcData.jointNumbers[subIndex][rpcData.subdev_jointsVectorLen[subIndex]] = device.lut[joints[j]].offset + rpcData.subdevices_p[subIndex]->base;
        rpcData.values[subIndex][rpcData.subdev_jointsVectorLen[subIndex]] = accs[j];
        rpcData.subdev_jointsVectorLen[subIndex]++;
    }

    for (subIndex = 0; subIndex < rpcData.deviceNum; subIndex++) {
        if (rpcData.subdevices_p[subIndex]->pos) {
            ret = ret && rpcData.subdevices_p[subIndex]->pos->setRefAccelerations(rpcData.subdev_jointsVectorLen[subIndex], rpcData.jointNumbers[subIndex], rpcData.values[subIndex]);
        } else {
            ret = false;
        }
    }
    rpcDataMutex.unlock();
    return ret;
}


bool ControlBoardWrapperCommon::getRefAcceleration(int j, double* acc)
{
    int off;
    try {
        off = device.lut.at(j).offset;
    } catch (...) {
        yCError(CONTROLBOARDWRAPPER, "Joint number %d out of bound [0-%d] for part %s", j, controlledJoints, partName.c_str());
        return false;
    }
    int subIndex = device.lut[j].deviceEntry;

    SubDevice* p = device.getSubdevice(subIndex);

    if (!p) {
        return false;
    }

    if (p->pos) {
        return p->pos->getRefAcceleration(off + p->base, acc);
    }
    *acc = 0;
    return false;
}


bool ControlBoardWrapperCommon::getRefAccelerations(double* accs)
{
    auto* references = new double[device.maxNumOfJointsInDevices];
    bool ret = true;
    for (unsigned int d = 0; d < device.subdevices.size(); d++) {
        SubDevice* p = device.getSubdevice(d);
        if (!p) {
            ret = false;
            break;
        }

        if ((p->pos) && (ret = p->pos->getRefAccelerations(references))) {
            for (int juser = p->wbase, jdevice = p->base; juser <= p->wtop; juser++, jdevice++) {
                accs[juser] = references[jdevice];
            }
        } else {
            printError("getRefAccelerations", p->id, ret);
            ret = false;
            break;
        }
    }

    delete[] references;
    return ret;
}


bool ControlBoardWrapperCommon::getRefAccelerations(const int n_joints, const int* joints, double* accs)
{
    bool ret = true;

    rpcDataMutex.lock();
    //Reset subdev_jointsVectorLen vector
    memset(rpcData.subdev_jointsVectorLen, 0x00, sizeof(int) * rpcData.deviceNum);

    // Create a map of joints for each subDevice
    int subIndex = 0;
    for (int j = 0; j < n_joints; j++) {
        subIndex = device.lut[joints[j]].deviceEntry;
        rpcData.jointNumbers[subIndex][rpcData.subdev_jointsVectorLen[subIndex]] = device.lut[joints[j]].offset + rpcData.subdevices_p[subIndex]->base;
        rpcData.subdev_jointsVectorLen[subIndex]++;
    }

    for (subIndex = 0; subIndex < rpcData.deviceNum; subIndex++) {
        if (rpcData.subdevices_p[subIndex]->pos) {
            ret = ret && rpcData.subdevices_p[subIndex]->pos->getRefAccelerations(rpcData.subdev_jointsVectorLen[subIndex], rpcData.jointNumbers[subIndex], rpcData.values[subIndex]);
        } else {
            ret = false;
        }
    }

    if (ret) {
        // ReMix values by user expectations
        for (int i = 0; i < rpcData.deviceNum; i++) {
            rpcData.subdev_jointsVectorLen[i] = 0; // reset tmp index
        }

        // fill the output vector
        for (int j = 0; j < n_joints; j++) {
            subIndex = device.lut[joints[j]].deviceEntry;
            accs[j] = rpcData.values[subIndex][rpcData.subdev_jointsVectorLen[subIndex]];
            rpcData.subdev_jointsVectorLen[subIndex]++;
        }
    } else {
        for (int j = 0; j < n_joints; j++) {
            accs[j] = 0;
        }
    }
    rpcDataMutex.unlock();
    return ret;
}


bool ControlBoardWrapperCommon::stop(int j)
{
    int off;
    try {
        off = device.lut.at(j).offset;
    } catch (...) {
        yCError(CONTROLBOARDWRAPPER, "Joint number %d out of bound [0-%d] for part %s", j, controlledJoints, partName.c_str());
        return false;
    }
    int subIndex = device.lut[j].deviceEntry;

    SubDevice* p = device.getSubdevice(subIndex);

    if (!p) {
        return false;
    }

    if (p->pos) {
        return p->pos->stop(off + p->base);
    }
    return false;
}


bool ControlBoardWrapperCommon::stop()
{
    bool ret = true;

    for (int l = 0; l < controlledJoints; l++) {
        int off = device.lut[l].offset;
        int subIndex = device.lut[l].deviceEntry;

        SubDevice* p = device.getSubdevice(subIndex);

        if (!p) {
            return false;
        }

        if (p->pos) {
            ret = ret && p->pos->stop(off + p->base);
        } else {
            ret = false;
        }
    }
    return ret;
}


bool ControlBoardWrapperCommon::stop(const int n_joints, const int* joints)
{
    bool ret = true;

    rpcDataMutex.lock();
    //Reset subdev_jointsVectorLen vector
    memset(rpcData.subdev_jointsVectorLen, 0x00, sizeof(int) * rpcData.deviceNum);

    // Create a map of joints for each subDevice
    int subIndex = 0;
    for (int j = 0; j < n_joints; j++) {
        subIndex = device.lut[joints[j]].deviceEntry;
        rpcData.jointNumbers[subIndex][rpcData.subdev_jointsVectorLen[subIndex]] = device.lut[joints[j]].offset + rpcData.subdevices_p[subIndex]->base;
        rpcData.subdev_jointsVectorLen[subIndex]++;
    }

    for (subIndex = 0; subIndex < rpcData.deviceNum; subIndex++) {
        if (rpcData.subdevices_p[subIndex]->pos) {
            ret = ret && rpcData.subdevices_p[subIndex]->pos->stop(rpcData.subdev_jointsVectorLen[subIndex], rpcData.jointNumbers[subIndex]);
        } else {
            ret = false;
        }
    }
    rpcDataMutex.unlock();
    return ret;
}


bool ControlBoardWrapperCommon::getNumberOfMotors(int* num)
{
    *num = controlledJoints;
    return true;
}


bool ControlBoardWrapperCommon::getCurrents(double* vals)
{
    auto* currs = new double[device.maxNumOfJointsInDevices];
    bool ret = true;
    for (unsigned int d = 0; d < device.subdevices.size(); d++) {
        ret = false;
        SubDevice* p = device.getSubdevice(d);
        if (!p) {
            break;
        }

        if (p->iCurr) {
            ret = p->iCurr->getCurrents(currs);
        } else if (p->amp) {
            ret = p->amp->getCurrents(currs);
        }

        if (ret) {
            for (int juser = p->wbase, jdevice = p->base; juser <= p->wtop; juser++, jdevice++) {
                vals[juser] = currs[jdevice];
            }
        } else {
            printError("getCurrents", p->id, ret);
            break;
        }
    }
    delete[] currs;
    return ret;
}


bool ControlBoardWrapperCommon::getCurrent(int j, double* val)
{
    int off;
    try {
        off = device.lut.at(j).offset;
    } catch (...) {
        yCError(CONTROLBOARDWRAPPER, "Joint number %d out of bound [0-%d] for part %s", j, controlledJoints, partName.c_str());
        return false;
    }
    int subIndex = device.lut[j].deviceEntry;

    SubDevice* p = device.getSubdevice(subIndex);
    if (!p) {
        return false;
    }

    if (p->iCurr) {
        return p->iCurr->getCurrent(off + p->base, val);
    }

    if (p->amp) {
        return p->amp->getCurrent(off + p->base, val);
    }
    *val = 0.0;
    return false;
}
