APP = write-on

$(APP): main.m
	clang -framework Cocoa -o $(APP) main.m

clean:
	rm -f $(APP)

.PHONY: clean
