---
title: "Offline Go Modules"
date: 2021-11-04T15:11:42-04:00
draft: false
toc: true
tags: ["golang", "modules", "offline"]
categories: ["golang"]
---

# Using go mod vendor

### With an existing module

- copy `go.mod` and `go.sum` files from the offline PC to the internet PC

### New module

- create a folder on machine with internet access
- create a go module : `go mod init offline` 

### Download dependencies via vendor folder

- create a `offline_modules.go` file :

```bash
touch offline_modules.go
```

- add the dependencies you want to download (use `_`) :

```go
package offline_modules

import (
	_ "github.com/gorilla/mux"
	_ "github.com/sirupsen/logrus"
)

func main() {}
```

- To download dependencies, run: 
 ```bash
 go mod vendor
 ```

- the vendor folder should have new folders in it representing dependencies

### Back to offline

- copy `go.mod`, `go.sum` and `vendor` directory to offline machine
- run your go commands with the flag `-mod=vendor` like:
```go
go run -mod=vendor main.go
 ```

