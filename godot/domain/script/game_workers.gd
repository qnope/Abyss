class_name GameWorkers
extends RefCounted
## lib/domain/script/game_workers.dart: shares numbered jobs between up to
## `workers` workers and keeps their results in job order.
##
## Dart plays each job on an isolate of its own (isolate_job_io.dart), or
## inline where there is none (isolate_job_stub.dart, the web). Godot has
## no isolate, and the rules keep caches no two threads may share: the jobs
## run inline, one after the other, as on the web. The results, and their
## order, are those of Dart; only the time differs.

var workers: int


func _init(workers_: int) -> void:
	if workers_ < 1:
		push_error("GameWorkers: %d workers, at least 1" % workers_)
	workers = workers_


## Runs `job(0)` to `job(count - 1)` and returns their results in order.
func map(count: int, job: Callable) -> Array:
	var results := []
	for index: int in count:
		results.append(job.call(index))
	return results
