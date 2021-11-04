---
title: "Offline Go Modules"
date: 2021-11-04T15:11:42-04:00
draft: true
---

# golang offline module dependencies download

## Using go mod vendor

### 0 - With an existing module

- copy `go.mod` and `go.sum` files from the offline PC to the internet PC

### 0bis - New module

- create a folder on the internet PC
- create a go module : `go mod init test` 

### 1 - Download dependencies via vendor folder

- create a `offline_modules.go` file :

```
package offline_modules

func main() {}
```

- add the dependencies you want to download (use `_`) :

```
package offline_modules

import (
	_ "github.com/gorilla/mux"
	_ "github.com/sirupsen/logrus"
)

func main() {}
```

- run `go mod vendor`

- the vendor folder should have new folders in it representing dependencies

### 2 - Back to offline

- copy `go.mod`, `go.sum` and `vendor`
- paste them on your offline PC, edit `go.mod` module name if necessary
- run your go commands with the flag `-mod=vendor` like `go run -mod=vendor main
.go`

