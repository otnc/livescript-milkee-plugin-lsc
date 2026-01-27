# milkee-plugin-lsc

This is a plugin for [milkee](https://www.npmjs.com/package/milkee) .

A tiny plugin for handling LiveScript in Milkee.

## Usage

### setup

#### coffee.config.cjs

```js
const plugin = require('milkee-plugin-lsc');

module.exports = {
  // ...
  milkee: {
    plugins: [
      plugin(),
      // ...
    ]
  }
}
```

### Run

```sh
milkee
# or
npx milkee
```
