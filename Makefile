BIN = writer
APP = Writer

$(BIN): main.m
	clang -framework Cocoa -o $(BIN) main.m

icon.icns: icon.png
	mkdir -p icon.iconset
	sips -z 16 16 icon.png --out icon.iconset/icon_16x16.png
	sips -z 32 32 icon.png --out icon.iconset/icon_16x16@2x.png
	sips -z 32 32 icon.png --out icon.iconset/icon_32x32.png
	sips -z 64 64 icon.png --out icon.iconset/icon_32x32@2x.png
	sips -z 128 128 icon.png --out icon.iconset/icon_128x128.png
	sips -z 256 256 icon.png --out icon.iconset/icon_128x128@2x.png
	sips -z 256 256 icon.png --out icon.iconset/icon_256x256.png
	sips -z 512 512 icon.png --out icon.iconset/icon_256x256@2x.png
	sips -z 512 512 icon.png --out icon.iconset/icon_512x512.png
	sips -z 1024 1024 icon.png --out icon.iconset/icon_512x512@2x.png
	iconutil -c icns icon.iconset -o icon.icns
	rm -rf icon.iconset

app: $(BIN) icon.icns
	mkdir -p $(APP).app/Contents/MacOS
	mkdir -p $(APP).app/Contents/Resources
	cp $(BIN) $(APP).app/Contents/MacOS/
	cp Info.plist $(APP).app/Contents/
	cp icon.icns $(APP).app/Contents/Resources/

clean:
	rm -f $(BIN)
	rm -f icon.icns
	rm -rf $(APP).app

.PHONY: clean app
