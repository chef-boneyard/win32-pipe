require 'ffi'

module Windows
  module Functions
    extend FFI::Library

    typedef :ulong, :dword
    typedef :uintptr_t, :handle
    typedef :pointer, :ptr
    typedef :string, :str

    ffi_lib :kernel32

    module FFI::Library
      # Wrapper method for attach_function + private
      def attach_pfunc(*args)
        attach_function(*args)
        private args[0]
      end
    end

    attach_pfunc :CloseHandle, [:handle], :bool
    attach_pfunc :ConnectNamedPipe, [:handle, :ptr], :bool
    attach_pfunc :CreateEvent, :CreateEventA, [:ptr, :int, :int, :str], :handle
    attach_pfunc :CreateFile, :CreateFileA, [:str, :dword, :dword, :ptr, :dword, :dword, :handle], :handle
    attach_pfunc :CreateNamedPipe, :CreateNamedPipeA, [:str, :dword, :dword, :dword, :dword, :dword, :dword, :ptr], :handle
    attach_pfunc :CreatePipe, [:ptr, :ptr, :ptr, :dword], :bool
    attach_pfunc :DisconnectNamedPipe, [:handle], :bool
    attach_pfunc :FlushFileBuffers, [:handle], :bool
    attach_pfunc :GetLastError, [], :dword
    attach_pfunc :GetOverlappedResult, [:handle, :ptr, :ptr, :int], :bool
    attach_pfunc :ReadFile, [:handle, :buffer_out, :dword, :ptr, :ptr], :bool
    attach_pfunc :WaitForSingleObject, [:handle, :dword], :dword
    attach_pfunc :WaitNamedPipe, :WaitNamedPipeA, [:str, :dword], :bool
    attach_pfunc :WriteFile, [:handle, :buffer_in, :dword, :ptr, :ptr], :bool
  end
end
