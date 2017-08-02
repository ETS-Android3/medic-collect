ADB = ${ANDROID_HOME}/platform-tools/adb
EMULATOR = ${ANDROID_HOME}/tools/emulator
GRADLEW = ./gradlew --daemon --parallel

ifdef ComSpec	 # Windows
  # Use `/` for all paths, except `.\`
  ADB := $(subst \,/,${ADB})
  EMULATOR := $(subst \,/,${EMULATOR})
  GRADLEW := $(subst /,\,${GRADLEW})
endif

.PHONY: android-emulator android-logs base clean default deploy deploy-unbranded update-bikram

default: deploy-unbranded android-logs

android-emulator:
	nohup ${EMULATOR} -avd test -wipe-data > emulator.log 2>&1 &
	${ADB} wait-for-device
android-logs:
	${ADB} shell logcat

deploy-unbranded:
	${GRADLEW} installDemoDebug

deploy: clean
	${GRADLEW} --daemon --parallel assembleDebug
	rm -f build/outputs/apk/*-unaligned.apk
	ls build/outputs/apk/*-debug.apk | \
					xargs -n1 ${ADB} install -r

clean:
	rm -rf build/outputs/apk/

base: clean
	${GRADLEW} --daemon --parallel installBaseDebug
