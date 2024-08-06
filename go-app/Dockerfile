FROM golang:alpine3.20

WORKDIR /deployments

COPY go.mod ./
RUN go mod download

COPY *.go ./

EXPOSE 8080

RUN go build -o /go-srv

CMD [ "/go-srv" ]