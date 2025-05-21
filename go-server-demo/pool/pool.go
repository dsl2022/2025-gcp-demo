package pool

import (
	"context"
	"errors"

	pb "github.com/dsl2022/2025-gcp-demo/go-server-demo/transfer"
)

type Job struct {
	Ctx     context.Context
	Payload *pb.TransferRequest
	Done    chan Result
}

type Result struct {
	Resp *pb.TransferResponse
	Err  error
}

type Pool struct {
	jobs       chan *Job
	maxWorkers int
}

func NewPool(maxWorkers, queneSize int) *Pool {
	return &Pool{
		jobs:       make(chan *Job, queneSize),
		maxWorkers: maxWorkers,
	}
}

func (p *Pool) Start(handler func(*Job)) {
	for i := 0; i < p.maxWorkers; i++ {
		go func(id int) {
			for job := range p.jobs {
				handler(job)
			}
		}(i)
	}
}

var ErrFull = errors.New("too many concurrent requests")

func (p *Pool) Enqueue(job *Job) error {
	select {
	case p.jobs <- job:
		return nil
	default:
		return ErrFull
	}
}
