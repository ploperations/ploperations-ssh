# Manage an OpenSSH server

~~~
include ssh::server
~~~

## Known issues

  * The Cygwin SSH set up script is finicky and unreliable. You have to run the
    agent a few times _from the Windows command line_ in order to have a
    successful run. Once it has succeeded, it should continue to succeed.
  * The README is sparse and needs to be filled out.
