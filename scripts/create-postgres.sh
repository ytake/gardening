#!/usr/bin/env bash

DB=$1;
su postgres -c "createdb -O gardening '$DB' || true"
