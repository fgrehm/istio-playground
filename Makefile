kiali:
	docker-compose run --rm istioctl dashboard kiali

demo:
	./01-demo/main

httpbin-ingress:
	./02-httpbin-ingress/main

httpbin-tls:
	./03-httpbin-tls/main

wildcard-ca-tls:
	./04-wildcard-ca-tls/main

down:
	docker-compose down

clobber:
	docker-compose down -v
