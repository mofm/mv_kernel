# mv-kernel 
mv-kernel, kernel configuration, build tool for micro virtual machine.

## 1. Quick Start
mv-kernel, fast way to build kernel for micro virtual machine.

### 1.1. Clone mv-kernel
```bash
$ git clone https://github.com/mofm/mv-kernel.git
$ cd mv-kernel
```

### 1.2. Build
Download kernel source code, and build kernel.
```bash
$ make all
```

Finally, you can find the kernel image in `images` directory.


## 2. All target of Makefile
- Only download and exract kernel source code.
```bash
$ make download
```

- Configure kernel.
```bash
$ make config
```

- Build kernel.
```bash
$ make build
```

- Download and extract kernel source code, configure kernel, build kernel. Execute all target.(download + config + build)
```bash
$ make all
```

- Clean kernel source code for reconfigure and rebuild.(soft clean)
```bash
$ make clean
```

- Clean all build files, kernel directory and kernel images.(hard clean)
```bash
$ make clean-all
```

- Help
```bash
$ make help
```
