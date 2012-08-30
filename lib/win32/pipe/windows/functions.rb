require 'ffi'

module Windows
  module Functions
    extend FFI::Library
    ffi_lib :kernel32

    module FFI::Library
      # Wrapper method for attach_function + private
      def attach_pfunc(*args)
        attach_function(*args)
        private args[0]
      end
    end

    attach_pfunc :CloseHandle, [:ulong], :bool
    attach_pfunc :ConnectNamedPipe, [:ulong, :pointer], :bool
    attach_pfunc :CreateEvent, :CreateEventA, [:pointer, :bool, :bool, :string], :ulong
    attach_pfunc :CreateFile, :CreateFileA, [:string, :ulong, :ulong, :pointer, :ulong, :ulong, :ulong], :ulong
    attach_pfunc :CreateNamedPipe, :CreateNamedPipeA, [:string, :ulong, :ulong, :ulong, :ulong, :ulong, :ulong, :pointer], :ulong
    attach_pfunc :CreatePipe, [:pointer, :pointer, :pointer, :ulong], :bool
    attach_pfunc :DisconnectNamedPipe, [:ulong], :bool
    attach_pfunc :FlushFileBuffers, [:ulong], :bool
    attach_pfunc :GetLastError, [], :ulong
    attach_pfunc :GetOverlappedResult, [:ulong, :pointer, :pointer, :bool], :bool
    attach_pfunc :ReadFile, [:ulong, :pointer, :ulong, :pointer, :pointer], :bool
    attach_pfunc :WaitForSingleObject, [:ulong, :ulong], :ulong
    attach_pfunc :WaitNamedPipe, :WaitNamedPipeA, [:string, :ulong], :bool
    attach_pfunc :WriteFile, [:ulong, :buffer_in, :ulong, :pointer, :pointer], :bool
  end
end
