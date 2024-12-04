#   Copyright (C) 2023 John Törnblom
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING. If not see
# <http://www.gnu.org/licenses/>.

PS5_HOST ?= 192.168.88.11
PS5_PORT ?= 9021

ifdef PS5_PAYLOAD_SDK
    include $(PS5_PAYLOAD_SDK)/toolchain/prospero.mk
else
    $(error PS5_PAYLOAD_SDK is undefined)
endif

ELF := code_injection_tests.elf

CFLAGS := -Wall -Werror -g

all: $(ELF)

$(ELF): src/*.c
		$(CC) $(CFLAGS) -o $@ $^

clean:
		rm -f $(ELF)

test: $(ELF)
		$(PS5_DEPLOY) -h $(PS5_HOST) -p $(PS5_PORT) $^

debug: $(ELF)
        gdb \
        -ex "target extended-remote $(PS5_HOST):2159" \
        -ex "file $(ELF)" \
        -ex "remote put $(ELF) /data/$(ELF)" \
        -ex "set remote exec-file /data/$(ELF)" \
        -ex "start"
