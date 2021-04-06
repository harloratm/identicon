# Identicon

Both a CLI and GUI tool to generate an identicon png image from a string.

![Screenshot_2021-04-06_15-32-09](https://user-images.githubusercontent.com/64407038/113719190-a4b9fd00-96ed-11eb-952c-88b9530e8227.png)

## Building

### CLI

```
mix escript.build
```

### GUI

```
MIX_ENV=gui mix escript.build
```

## Running

### CLI

```
./identicon --help
```

### GUI

```
./wxidenticon
```

## Help

```
Usage: identicon [options] WORD
Options:
  -o FILE, --output FILE      The generated image filename (the .png extension is
                              automatically appended).
  -s SIZE, --size SIZE        The size of the square image (defaults to 250).
  -h, --help                  Print this message and exit.
```
