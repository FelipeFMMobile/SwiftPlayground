import Foundation

class MyTaskExecutor {
    var taskCounter = 0
    func runTasksSerial() async {
        await taskRun()
        await taskRun()
        await taskRun()
        await taskRun()
        await taskRun()
        await taskRun()

    }

    func runTasksParalell() async {
        async let task1: () = taskRun()
        async let task2: () = taskRun()
        async let task3: () = taskRun()
        async let task4: () = taskRun()
        async let task5: () = taskRun()
        async let task6: () = taskRun()
        let _ = await [task1, task2, task3, task4, task5, task6]
    }

    func taskRun() async {
        // if we cancel but wont check for cancelled, sleep will fail but execute the next code.
        // guard !Task.isCancelled else { return }
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        taskCounter += 1
        printThread()
    }

    private func printThread() {
        print("counter:\(self.taskCounter)")
        print("thread: \(Thread.current)")
        print("isMain: \(Thread.current.isMainThread)")
        print("----")
    }
}

class Hub {
    var taskExecutor: MyTaskExecutor?

    init() async {
        self.taskExecutor = MyTaskExecutor()
        
        // change for runTasksSerial or runTasksParalell
        let taskHandle = Task {
            await self.taskExecutor?.runTasksSerial()
        }
        
        //self.taskExecutor = MyTaskExecutor()
        // what happens in serial, if we dealloc the executor class?
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 6) {
            self.taskExecutor = nil
            print("----------------")
            print("dealloced object")
            print("----------------")
            // if task was not cancelled, all jobs still running.
            //taskHandle.cancel()
        }
        
    }
}

Task {
    let hub = await Hub()
    try? Task.checkCancellation()
}


