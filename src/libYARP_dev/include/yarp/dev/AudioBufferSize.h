/*
 * Copyright (C) 2006-2019 Istituto Italiano di Tecnologia (IIT)
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms of the
 * BSD-3-Clause license. See the accompanying LICENSE file for details.
 */

#ifndef YARP_DEV_AUDIOBUFFERSIZE_H
#define YARP_DEV_AUDIOBUFFERSIZE_H

#include <yarp/os/Portable.h>
#include <yarp/os/PortReader.h>
#include <yarp/os/PortWriter.h>
#include <yarp/dev/api.h>
#include <audioBufferSizeData.h>

namespace yarp {
namespace dev {

template <typename SAMPLE>
class CircularAudioBuffer;

class YARP_dev_API AudioBufferSize :
        private audioBufferSizeData
{
    template <typename SAMPLE>
    friend class CircularAudioBuffer;

public:
    size_t getSamples() { return m_samples; }
    size_t getChannels() { return m_channels; }
    size_t getBufferElements() { return size; }
    size_t getBytes() { return m_samples * m_channels * m_depth; }

    bool read(yarp::os::idl::WireReader& reader) override { return audioBufferSizeData::read(reader); }
    bool write(const yarp::os::idl::WireWriter& writer) const override { return audioBufferSizeData::write(writer); }
    bool read(yarp::os::ConnectionReader& reader) override { return audioBufferSizeData::read(reader); }
    bool write(yarp::os::ConnectionWriter& writer) const override { return audioBufferSizeData::write(writer); }

    AudioBufferSize() : audioBufferSizeData() {}

            //this casts are due to the fact the it is not yet possibile to define an unsigned type in thrift
    AudioBufferSize(size_t samples, size_t channels, size_t depth_in_bytes) :
            audioBufferSizeData(static_cast<int32_t>(samples),
                                static_cast<int32_t>(channels),
                                static_cast<int32_t>(depth_in_bytes),
                                static_cast<int32_t>(samples * channels))
    {
    }
};

} // namespace dev
} // namespace yarp

#endif // YARP_DEV_AUDIOBUFFERSIZE_H
