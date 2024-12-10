package query

func New(db string) *Queries {
	return &Queries{db: db}
}

type Queries struct {
	db string
}
