# 关于Linux下主线程与SDK线程通信交互说明

Linux SaaS SDK运行在一个独立子线程中，所有的接口回调函数也都默认在该子线程中执行，因此SDK提供了`IThreadDispatcher`接口，通过实现该接口可实现用户自定义的线程调度。只需要将实现对象的实例传入IWemeetSDK，所有接口回调函数将会自动通过该调度器执行。

IThreadDispatcher当前只需要子类型实现一个方法：

``` c++
void SyncRunOnMainThread(Runnable runnable, void* user_data);
```

其中Runnable为回调函数类型，签名如下：

``` c++
typedef void(*Runnable)(void*);
```

`IThreadDispatcher`是用户自行实现的，对于实现来讲，必须满足以下约定，否则结果行为将是未定义的：

1. 实现必须调用传入的runnable函数，并且透传`user_data`参数。
2. 实现必须同步执行runnable函数，因为回调函数可能会访问栈上变量。

一般情况下，使用`IThreadDispatcher`来将回调函数调度到主线程（UI线程）去运行，避免在每个回调函数中重复做线程同步的工作。

---

对于QT程序，在`res`目录下提供了`qt_dispatcher.cpp`和`qt_dispatcher.h`两个文件可供参考实现。该实现将SDK回调函数调度到QT UI主线程同步执行，因此如同一般的回调函数一样，应当避免在回调函数中使用阻塞调用（例如阻塞模态弹窗等）。

需要注意的是：`QtMainThreadDispatcher`对象的构造必须在UI线程中被调用，以确保QT对象线程上下文正确。

对于命令行程序，通常情况下不存在所谓的UI线程，但也可选使用`IThreadDispatcher`来实现统一的线程同步行为，确保回调函数都运行在指定的线程中。

对于使用其他UI框架的程序，需要自行参考上述QT实现，适配所使用的UI框架。
