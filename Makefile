kiali:
	docker-compose run --rm istioctl dashboard kiali

demo:
	./scripts/demo

httpbin-ingress:
	./scripts/httpbin-ingress

down:
	docker-compose down

clobber:
	docker-compose down -v
