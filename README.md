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


| CPU | TIMING | MAX_TRIES | CACHE_HIT_THRESHOLD | Results |
| ----- | ---------- | -------------- | --------------------------------- | ---------- |
| Cortex A8  | PTHREAD | 999 | 80 | Too many cache hits |
| Cortex A8 | PTHREAD | 5500 | 1 | Still too many cache hits! |
| Cortex A8 | POSIX | 999 | 80 | Unclear, probably too many cache hits |
| Cortex A8 | POSIX | 999 | 1 | Unclear |
| Cortex A8 | PERFEVENT | 999 | 80 | No perf event interface |
| Cortex A8 | REGISTER | 999 | 80 | Illegal instruction |
| Cortex A8 | LIBFLUSH with POSIX | 999 | 80 | `find_congruent_addresses: assertion "found == ADDRESS_COUNT" failed` and `Segmentation fault` |
| Cortex A8 | LIBFLUSH with PTHREAD | 999 | 80 | `find_congruent_addresses: assertion "found == ADDRESS_COUNT" failed` and `Segmentation fault` |
| Cortex A8 | LIBFLUSH with Register | 999 | 80 | `Illegal instruction ` |
| Cortex A8 | LIBFLUSH with PERFEVENT | 999 | 80 | No perf event interface |
| Cortex A53 | PTHREAD | 999 | 80 | too many cache hits. Decrease threshold below 5 |
| Cortex A53 | PTHREAD | 5500 | 1 | Unclear. Still too many cache hits! |
| Cortex A53 | PTHREAD | 2500 | 4 | Unclear. The correct character is a cache hit, but so are several others... |
| Cortex A53 | POSIX | 999 | 80 | No cache hit recorded. Increase threshold around 500 |
| Cortex A53 | POSIX | 5500 | 380 | Unclear |
| Cortex A53 | REGISTER | | | Crash |
| Cortex A53 | PERFEVENT | |  | No perf event interface |

## Conclusion / status

- Perf event is not working on my devices.
- Register cannot work as such. PMU must be enabled via a kernel module. I haven't done this yet.
- I get the same results with Libflush or with my own implementation - which is basically just to check my own implementation is correct.
- Dedicated thread seems unprecise.
- `clock_getttime()` gives the best results, but yet unable to recover the secret. Not sure if it's bad configuration, bad luck, or just that the device is not vulnerable to Spectre.












