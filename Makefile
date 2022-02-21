kiali:
	docker-compose run --rm istioctl dashboard kiali

demo:
	./01-demo/main

httpbin:
	./02-httpbin/main

httpbin-tls:
	./03-httpbin-tls/main

wildcard-ca-tls:
	./04-wildcard-ca-tls/main

down:
	docker-compose down

clobber:
	rm -rf certs/
	docker-compose down -v
