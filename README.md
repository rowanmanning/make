
# Make

Reusable Makefiles for my open source projects.


## Usage

Install with:

```sh
npm install --save-dev @rowanmanning/make
```

Create a `Makefile` in the root of your project and add the [boilerplate content](boilerplate.mk):

```make
# Reusable Makefile
# ------------------------------------------------------------------------
# This section of the Makefile should not be modified, it includes
# commands from my reusable Makefile: https://github.com/rowanmanning/make
include node_modules/@rowanmanning/make/<LANGUAGE>/index.mk
# [edit below this line]
# ------------------------------------------------------------------------
```

where `<LANGUAGE>` is one of the following:

  * javascript

Now you can use the following commands, based on which language you choose.

### JavaScript

#### Commands

  * `all`: Run the `install` and `ci` tasks.

  * `ci`: Run the `verify` and `test` tasks.

  * `clean`: Cleans the working directory. Relies on `git`.

  * `install`: Runs `npm install` but only if `package.json` has changed more recently than the `node_modules` folder. This speeds up installing to be instant if nothing needs doing. This task also prunes extra dependencies.

  * `verify`: Run the `verify-javascript` and `verify-dust` tasks.

  * `verify-javascript`: Run the `verify-eslint`, `verify-jshint`, and `verify-jscs` tasks.

  * `verify-dust`: If an `.dustmiterc` file is present in the project root, run [Dustmite] against the code.

  * `verify-eslint`: If an `.eslintrc` file is present in the project root, run [ESLint] against the code.

  * `verify-jscs`: If a `.jscsrc` file is present in the project root, run [JSCS] against the code.

  * `verify-jshint`: If a `.jshintrc` file is present in the project root, run [JSHint] against the code.

  * `verify-coverage`: If a `coverage/lcov-report` folder is present in the project root and the [`nyc`][nyc] or [`istanbul`][istanbul] module is installed, check that coverage is above `90%`. This is configurable by specifying `export EXPECTED_COVERAGE := <value>` in your dependant Makefile.

  * `test`: Run the `test-unit-coverage`, `verify-coverage`, and `test-integration` tasks.

  * `test-unit`: If a `test/unit` folder is present in the project root, run [Mocha] or [Jest] recursively on any files that end in `.test.js`.

  * `test-unit-coverage`: If a `test/unit` folder is present in the project root and the [`nyc`][nyc] or [`istanbul`][istanbul] module is installed, run [Mocha] recursively on any files that end in `.test.js` with coverage reporting. If `instanbul` or `nyc` are _not_ present, fall back to running [Jest] with coverage. If Jest is not present, fall back to running `make test-unit`.

  * `test-integration`: If a `test/integration` folder is present in the project root, run [Mocha] or [Jest] recursively on any files that end in `.test.js`.

#### Helpers

  * The `TASK_DONE` output helper allows you to quickly output a check-marked notice after a task has completed successfully. Just add it to your own tasks like this:

    ```make
    mytask:
    	@do something
    	@$(TASK_DONE)
    ```

  * The folder `./node_modules/.bin` is added to the `PATH` environment variable so that you don't need to explicitly reference it in calls to further commands.


## License

ESLint Config is licensed under the [MIT] license.<br/>
Copyright &copy; 2017, Rowan Manning



[dustmite]: https://github.com/springernature/dustmite
[eslint]: http://eslint.org/
[istanbul]: https://github.com/gotwarlost/istanbul
[jest]: https://jestjs.io/
[jscs]: http://jscs.info/
[jshint]: http://jshint.com/
[mit]: LICENSE
[mocha]: https://mochajs.org/
[nyc]: https://github.com/istanbuljs/nyc
