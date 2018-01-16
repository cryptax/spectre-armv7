# Attempt of implementation of Spectre for ARMv7A

This is an *attempt* to implement **Spectre** on ARMv7-based Android smartphones.
ARM Cortex A53 is said **not to be vulnerable for Spectre**, I know, but still, I want to run a few tests. Okay?


## References

- [Spectre paper](https://spectreattack.com/spectre.pdf)
- [Spectre PoC from the paper](https://github.com/Eugnis/spectre-attack/blob/master/Source.c)
- [Implementation of Spectre for AArch64](https://github.com/V-E-O/PoC/tree/master/CVE-2017-5753)
- [Libflush from ARMageddon](https://github.com/iaik/armageddon)

## Run

### Pre-requisites

- [Android NDK](https://developer.android.com/ndk/index.html)
- Android SDK Platform packages (see [here](https://developer.android.com/studio/command-line/sdkmanager.html))
- Linux 64bits - if you not you'll need to tweak the compiler path in the `Makefile`.

### Compile

Edit the `Makefile` and update:

- `ANDROID_NDK`: provide the path to your Android NDK root directory
- `ANDROID_PLATFORM`: provide the name of your Android platform version. For example `android-22`.

Then:

```
$ make
```

### Run

Connect a smartphone (or an emulator).
Make sure it is seen by `adb devices`.

Then:

```
$ make run
```

### Options

I have implemented several different ways to measure time. Select the one you wish by changing `TFLAGS` in the `Makefile` or by specifying it as `make` argument:

```
$ make TFLAGS=-DTIMING_REGISTER all
```

| TFLAGS value | Description          | 
| ------------------ | ----------------------- | 
| -DTIMING_POSIX | Uses the POSIX function `clock_gettime()` |
| -DTIMING_PTHREAD | Uses a dedicated thread counter |
| -DTIMING_PERFEVENT | Uses the Performance Monitoring Unit |
| -DTIMING_REGISTER | Uses the Performance Monitor Control Register |
| -DTIMING_LIBFLUSH | Uses [Libflush](https://github.com/iaik/armageddon). |

To use [Libflush](https://github.com/iaik/armageddon), you must

1. Download and compile it. See instructions in [libflush](https://github.com/IAIK/armageddon/tree/master/libflush)
2. Copy the include file `libflush.h` and the compiled `libflush.a` into this directory
3. Compile with option `DTIMING_LIBFLUSH`

## Results

Those results apply to a smartphone with **ARM Cortex A53** cores.
Those cores are seen as **ARMv7** (I guess because the ROM does not have 64-bit enabled).
I compiled with Android **NDK r13b** and **platform 22** (Android 5.1).

| Option | Running details | Spectre | 
| --------- | --------------------- | ---------- |
| TIMING_POSIX | Runs but there is no obvious timing difference between cache hit and cache miss. Is that a problem of accuracy? | Fail or does not work yet |
| TIMING_PTHREAD | Runs but returns 0 for each timing. Is this a compiler optimization problem? | Fail or does not work yet. |
| TIMING_PERFEVENT | Assertion at runtime. No perf event interface available | Not Applicable |
| TIMING_REGISTER | Crashes? | No |
| TIMING_LIBFLUSH | Same results - depending on how libflush was compiled | - |









