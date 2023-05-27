#*******************************************************************************************
# Makefile
#
# Created by: Erik van der Tier
# on: 2023-04-09
#*******************************************************************************************
NAME = 	YAM3G
ADDR = 	0000
OUTDIR = build
BLD_NAME = $(OUTDIR)/$(NAME).bin

SRC = 	src/main.asm \
		src/init.asm \
		src/system.asm \
		src/yam3g.asm \
		src/playfield.asm \
		src/rnd.asm \
		src/audio.asm \
		src/defs/interrupt.asm \
		src/defs/tinyvicky.asm \
		src/defs/io.asm 

BINS =  tile_data/tileset.bin \
  	    tile_data/tileset.pal.bin		

MAPS =  tile_data/layer1.txm \
		tile_data/layer2.txm \
		tile_data/layer3.txm
		
OPTS = 	--long-address -b -fc

$(BLD_NAME): $(SRC) $(BINS) $(MAPS)
		64tass $(OPTS) $(SRC) -o $@ --list $(basename $@).lst --labels=$(basename $@).lbl

up: 	$(BLD_NAME)
		upload $(BLD_NAME) $(ADDR)


tileset: tile_data/demotiles.png
		pngtotile tile_data/demotiles.png -b tile_data/tileset.bin -p tile_data/tileset.pal.bin

clean:
		rm $(OUTDIR)/*

.PHONY: up clean