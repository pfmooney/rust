use crate::spec::TargetOptions;
use std::default::Default;

pub fn opts() -> TargetOptions {
    TargetOptions {
        dynamic_linking: true,
        executables: true,
        has_rpath: true,
        target_family: Some("unix".to_string()),
        is_like_solaris: true,
        eliminate_frame_pointer: false,

        // While we support ELF TLS, rust requires a way to register
        // cleanup handlers (in C, this would be something along the lines of:
        // void register_callback(void (*fn)(void *), void *arg);
        // (see src/libstd/sys/unix/fast_thread_local.rs) that is currently
        // missing in illumos.  For now at least, we must fallback to using
        // pthread_{get,set}specific.
        //has_elf_tls: true,

        // XXX: Currently, rust is invoking cc to link, which ends up
        // causing these to get included twice.  We should eventually transition
        // to having rustc invoke ld directly, in which case these will need to
        // be uncommented.
        //
        // We want XPG6 behavior from libc and libm.  See standards(5)
        //pre_link_objects_exe: vec![
        //    "/usr/lib/amd64/values-Xc.o".to_string(),
        //    "/usr/lib/amd64/values-xpg6.o".to_string(),
        //],

        .. Default::default()
    }
}
