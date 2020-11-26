# hwport-leak-detective

[개인공개프로젝트] glibc 할당자의 공식적인 hooking API interface (man malloc_hook 참고) 에 맞는 할당자 hook 구현을 통하여 여러가지 시도를 위해서 만들었던 개인 공개 프로젝트의 소스입니다.

빌드하면 "hwport-leak-detective.so" 가 생성됩니다. 이것을 가지고 특정 hook대상 프로그램 실행시 LD_PRELOAD 환경변수로 hook 하여 할당자를 override 실행하게 할 수 있습니다.

즉,

$ LD_PRELOAD=./hwport-leak-detective.so ./test
