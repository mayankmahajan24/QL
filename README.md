# QL 
QL Language and Compiler, for Programming Langauges and Translators Course Fall 2015

### Getting started
You should have OCaml version 4.02.3 and Java version 1.8.0_25 installed on your machine. If not, run the appropriate commands as outlined in the following docs: 
- https://ocaml.org/docs/install.html
- http://www.oracle.com/technetwork/java/javase/downloads/index.html

Clone our repo by running the following command in your terminal:
```bash
git clone https://github.com/mayankmahajan24/QL.git
```

### Run tests
To make sure everything is working locally, navigate to the root directory of QL and run the following command:
```bash
./run_unit_tests.sh
```

If this doesn't work, make sure that you can run the script as an executable by running the following command:
```bash
chmod 744 run_unit_tests.sh
```

If this still doesn't work, [open an issue!](https://github.com/mayankmahajan24/QL/issues/new) :)

### Run individual QL files
To run individual QL files, navigate to the root directory of QL and run the following commands:
```bash
compiler/qlc path_to_file/file.ql destination_file
compiler/ql destination_file
```
For example, if we wanted to run our first integration test, we would run:
```bash
compiler/qlc tests/integration-1.ql SpringCourses
compiler/ql SpringCourses
```

### Write QL code
For a comprehensive guide to our language, take a look at our Language Reference Manual [here](https://github.com/mayankmahajan24/QL/blob/master/docs/LanguageReference.md).

Also, please refer to our style guide [here](https://github.com/mayankmahajan24/QL/blob/master/docs/StyleGuide.md).

### Contribute
If you've made it this far, something has probably broken! We don't know why you'd want to contribute, but we'd love it if you did. At the very least, feel free to [open an issue](https://github.com/mayankmahajan24/QL/issues/new) or get in touch with us.

Have fun! Write QL code.

_The Coders (Matt Piccolella, Mayank Mahajan, Gary Lin, Anshul Gupta, Evan Tarrh)_

