BIN = writer
APP = Writer

$(BIN): main.m
	clang -framework Cocoa -o $(BIN) main.m

app: $(BIN)
	mkdir -p $(APP).app/Contents/MacOS
	mkdir -p $(APP).app/Contents/Resources
	cp $(BIN) $(APP).app/Contents/MacOS/
	cp Info.plist $(APP).app/Contents/
	cp icon.icns $(APP).app/Contents/Resources/

clean:
	rm -f $(BIN)
	rm -rf $(APP).app

.PHONY: clean app
