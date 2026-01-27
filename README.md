# milkee-plugin-lsc

This is a plugin for [milkee](https://www.npmjs.com/package/milkee) .

A tiny plugin for handling LiveScript in Milkee.

## Install

```sh
npm install --save-dev milkee-plugin-lsc livescript
```

## Configuration Example




In your `coffee.config.cjs` (`livescript` is required!):

```js
const plugin = require('milkee-plugin-lsc');
const livescript = require('livescript');

module.exports = {
  milkee: {
    plugins: [
      plugin({
        livescript: livescript // REQUIRED: pass require('livescript')
      })
    ]
  }
}
```

## Options



| Option      | Type   | Description                                    |
| ----------- | ------ | :--------------------------------------------- |
| livescript  | object | (Required) The result of require('livescript') |

> **Note:**
> Only the `livescript` property is accepted. All other properties (such as `output`, `entry`, `options`, etc.) are ignored.

## Run

```sh
npx milkee
# or
milkee
```
