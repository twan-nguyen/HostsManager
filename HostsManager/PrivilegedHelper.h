#ifndef PrivilegedHelper_h
#define PrivilegedHelper_h

#include <Security/Security.h>

/// Run a shell command with admin privileges (shows system auth dialog with Touch ID on macOS 14+).
/// Returns errAuthorizationSuccess on success, errAuthorizationCanceled if user cancelled.
OSStatus runPrivilegedShellCommand(const char *command);

#endif
