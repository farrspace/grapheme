# grapheme

> grapheme - a minimal unit of a writing system.

Or in this case, a minimal implementation of a text editing system.

# Building
Use a C compiler to compile `hack/winsize.c`, until I can find a better way to integrate it, or a better Crystal library to get the window size. Adjust the winsize path in `src/grapheme/window.cr` based on where you saved the source code.

```
crystal build src/grapheme.cr && ./grapheme
```

## License

MIT License. See `LICENSE` file in project root for full license.