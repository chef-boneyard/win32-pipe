require 'ffi'

module Windows
  module Structs
    extend FFI::Library

    # I'm assuming the anonymous struct for the internal union here.
    class Overlapped < FFI::Struct
      layout(
        :Internal, :uintptr_t,
        :InternalHigh, :uintptr_t,
        :Offset, :ulong,
        :OffsetHigh, :ulong,
        :hEvent, :uintptr_t
      )
    end
  end
end
