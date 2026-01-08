# DBML - Database Markup Language for Go

[![CI Status](https://github.com/zoobzio/dbml/workflows/CI/badge.svg)](https://github.com/zoobzio/dbml/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/zoobzio/dbml/graph/badge.svg?branch=main)](https://codecov.io/gh/zoobzio/dbml)
[![Go Report Card](https://goreportcard.com/badge/github.com/zoobzio/dbml)](https://goreportcard.com/report/github.com/zoobzio/dbml)
[![CodeQL](https://github.com/zoobzio/dbml/workflows/CodeQL/badge.svg)](https://github.com/zoobzio/dbml/security/code-scanning)
[![Go Reference](https://pkg.go.dev/badge/github.com/zoobzio/dbml.svg)](https://pkg.go.dev/github.com/zoobzio/dbml)
[![License](https://img.shields.io/github/license/zoobzio/dbml)](LICENSE)
[![Go Version](https://img.shields.io/github/go-mod/go-version/zoobzio/dbml)](go.mod)
[![Release](https://img.shields.io/github/v/release/zoobzio/dbml)](https://github.com/zoobzio/dbml/releases)

A Go package for building and generating [DBML (Database Markup Language)](https://dbml.dbdiagram.io/docs/) programmatically.

## Schema as Code

Define database schemas with Go's type safety and generate DBML for visualisation tools like dbdiagram.io:

```go
project := dbml.NewProject("ecommerce").
    WithDatabaseType("PostgreSQL")

project.AddTable(
    dbml.NewTable("orders").
        AddColumn(dbml.NewColumn("id", "bigint").WithPrimaryKey()).
        AddColumn(dbml.NewColumn("user_id", "bigint").
            WithRef(dbml.ManyToOne, "public", "users", "id")),
)

fmt.Println(project.Generate())
```

Schemas become testable, version-controlled, and composable.

## Installation

```bash
go get github.com/zoobzio/dbml
```

Requires Go 1.24 or higher.

## Quick Start

```go
package main

import (
    "fmt"
    "github.com/zoobzio/dbml"
)

func main() {
    project := dbml.NewProject("my_database").
        WithDatabaseType("PostgreSQL")

    users := dbml.NewTable("users").
        AddColumn(
            dbml.NewColumn("id", "bigint").
                WithPrimaryKey().
                WithIncrement(),
        ).
        AddColumn(
            dbml.NewColumn("email", "varchar(255)").
                WithUnique(),
        ).
        AddColumn(
            dbml.NewColumn("created_at", "timestamp").
                WithDefault("now()"),
        )

    project.AddTable(users)

    if err := project.Validate(); err != nil {
        panic(err)
    }

    fmt.Println(project.Generate())
}
```

## Examples

### Tables with Relationships

```go
users := dbml.NewTable("users").
    AddColumn(dbml.NewColumn("id", "bigint").WithPrimaryKey())

posts := dbml.NewTable("posts").
    AddColumn(dbml.NewColumn("id", "bigint").WithPrimaryKey()).
    AddColumn(
        dbml.NewColumn("user_id", "bigint").
            WithRef(dbml.ManyToOne, "public", "users", "id"),
    )

project.AddTable(users).AddTable(posts)
```

### Standalone Relationships

```go
ref := dbml.NewRef(dbml.ManyToOne).
    From("public", "posts", "user_id").
    To("public", "users", "id").
    WithOnDelete(dbml.Cascade).
    WithOnUpdate(dbml.Restrict)

project.AddRef(ref)
```

### Indexes

```go
// Simple index
table.AddIndex(dbml.NewIndex("email"))

// Composite index
table.AddIndex(
    dbml.NewIndex("user_id", "created_at").
        WithName("idx_user_created").
        WithUnique(),
)

// Expression-based index
table.AddIndex(
    dbml.NewExpressionIndex("date(created_at)").
        WithType("btree"),
)
```

### Enums

```go
status := dbml.NewEnum("order_status",
    "pending", "processing", "shipped", "delivered").
    WithNote("Order status values")

project.AddEnum(status)
```

### Table Groups

```go
group := dbml.NewTableGroup("User Management").
    AddTable("public", "users").
    AddTable("public", "roles").
    AddTable("public", "permissions")

project.AddTableGroup(group)
```

## Capabilities

| Feature | Description |
| ------- | ----------- |
| Type-safe schemas | Catch errors at compile time, not when generating output |
| Fluent builder API | Chainable methods make schema construction readable |
| Built-in validation | Validate schemas before generation to catch structural issues |
| Serialisation | Export schemas to JSON or YAML for storage and interchange |
| Minimal dependencies | Only requires `gopkg.in/yaml.v3` |

## Why dbml?

- **Schema as code** — Version control, test, and compose database schemas like any other Go code
- **Visualisation ready** — Generate DBML for tools like dbdiagram.io directly from your definitions
- **Single source of truth** — Define once, generate documentation and diagrams from the same source

## API Reference

### Core Types

- **Project** - Top-level container for database schema
- **Table** - Database table definition
- **Column** - Table column with type and constraints
- **Index** - Single, composite, or expression-based indexes
- **Ref** - Relationships between tables
- **Enum** - Enumeration types
- **TableGroup** - Logical grouping of tables

### Relationship Types

```go
const (
    OneToMany  RelType = "<"   // One-to-many
    ManyToOne  RelType = ">"   // Many-to-one
    OneToOne   RelType = "-"   // One-to-one
    ManyToMany RelType = "<>"  // Many-to-many
)
```

### Referential Actions

```go
const (
    Cascade    RefAction = "cascade"
    Restrict   RefAction = "restrict"
    SetNull    RefAction = "set null"
    SetDefault RefAction = "set default"
    NoAction   RefAction = "no action"
)
```

### Project Methods

- `NewProject(name string) *Project`
- `WithDatabaseType(dbType string) *Project`
- `WithNote(note string) *Project`
- `AddTable(table *Table) *Project`
- `AddEnum(enum *Enum) *Project`
- `AddRef(ref *Ref) *Project`
- `AddTableGroup(group *TableGroup) *Project`
- `Validate() error`
- `Generate() string`

### Table Methods

- `NewTable(name string) *Table`
- `WithSchema(schema string) *Table`
- `WithAlias(alias string) *Table`
- `WithNote(note string) *Table`
- `WithHeaderColor(color string) *Table`
- `AddColumn(column *Column) *Table`
- `AddIndex(index *Index) *Table`

### Column Methods

- `NewColumn(name, colType string) *Column`
- `WithPrimaryKey() *Column`
- `WithNull() *Column`
- `WithUnique() *Column`
- `WithIncrement() *Column`
- `WithDefault(value string) *Column`
- `WithCheck(constraint string) *Column`
- `WithNote(note string) *Column`
- `WithRef(relType RelType, schema, table, column string) *Column`

### Index Methods

- `NewIndex(columns ...string) *Index`
- `NewExpressionIndex(expressions ...string) *Index`
- `WithType(indexType string) *Index`
- `WithName(name string) *Index`
- `WithUnique() *Index`
- `WithPrimaryKey() *Index`
- `WithNote(note string) *Index`

### Ref Methods

- `NewRef(relType RelType) *Ref`
- `WithName(name string) *Ref`
- `From(schema, table string, columns ...string) *Ref`
- `To(schema, table string, columns ...string) *Ref`
- `WithOnDelete(action RefAction) *Ref`
- `WithOnUpdate(action RefAction) *Ref`
- `WithColor(color string) *Ref`

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## License

MIT
