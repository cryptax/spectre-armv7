ANDROID_NDK=/opt/android-ndk-r13b
ANDROID_PLATFORM=android-22
TFLAGS = -DTIMING_POSIX
CFLAGS = $(TFLAGS) -I$(ANDROID_NDK)/platforms/$(ANDROID_PLATFORM)/arch-arm/usr/include -pie -Wall -Wextra -march=armv7-a -std=c99 --sysroot=$(ANDROID_NDK)/platforms/$(ANDROID_PLATFORM)/arch-arm
LIBFLUSH_CFLAGS = -I. -L.
COMPILER_PATH=$(ANDROID_NDK)/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin
GCC = $(COMPILER_PATH)/arm-linux-androideabi-gcc
PROGRAM = spectre
SOURCE = source.c
LIBS = libflush.a


all: $(PROGRAM)

$(PROGRAM): $(SOURCE)
        ifeq ($(TFLAGS), -DTIMING_LIBFLUSH)
		$(GCC) $(CFLAGS) $(LIBFLUSH_CFLAGS) -o $@ $< $(LIBS)
        else
		$(GCC) $(CFLAGS) -o $@ $<
        endif

run: $(PROGRAM)
	adb push $< /data/local/tmp/$<
	adb shell chmod u+x /data/local/tmp/$<
	adb shell /data/local/tmp/$<

clean:
	rm -f $(PROGRAM) 
