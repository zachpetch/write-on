APP = write-on

$(APP): main.m
	clang -framework Cocoa -o $(APP) main.m

app: $(APP)
	mkdir -p $(APP).app/Contents/MacOS
	cp $(APP) $(APP).app/Contents/MacOS/
	cp Info.plist $(APP).app/Contents/

clean:
	rm -f $(APP)
	rm -rf $(APP).app

.PHONY: clean app
