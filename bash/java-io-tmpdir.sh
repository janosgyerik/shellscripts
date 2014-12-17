#!/bin/bash

java -XshowSettings 2>&1 | sed -ne 's/.*java.io.tmpdir = //p' | sed -ne 1p
