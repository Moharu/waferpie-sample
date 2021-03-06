Testing = require('waferpie').Testing
path = require 'path'
expect = require 'expect.js'

describe 'Ingredients', ->

    testing = null

    beforeEach ->
        testing = new Testing path.join(__dirname, '../../../../kitchen-coffee/')

    describe 'get', ->

        it 'should return all ingredients if no parameter is passed', (done) ->
            results = []
            mock =
                init: -> return
                mocked: true
                findAll: (params, callback) ->
                    callback(null, results)

            testing.mockModel 'Couchbase.Ingredient', mock

            testing.callController 'Couchbase.Ingredients', 'get', {}, (body, info) ->
                expect(body.count).to.be 0
                expect(body.data).to.be results
                expect(info.statusCode).to.be 200
                done()

        it 'should return a single ingredient if the id is supplied', (done) ->
            result = {}
            mock =
                init: -> return
                findById: (id, callback) ->
                    expect(id).to.be '1'
                    callback(null, result)

            testing.mockModel 'Couchbase.Ingredient', mock

            testing.callController 'Couchbase.Ingredients', 'get', segments: ['1'], (body, info) ->
                expect(body).to.be result
                expect(info.statusCode).to.be 200
                done()

        it 'should return 404 if the id was supplied and the record was not found', (done) ->
            mock =
                init: -> return
                findById: (id, callback) ->
                    callback(null, null)

            testing.mockModel 'Couchbase.Ingredient', mock
            testing.callController 'Couchbase.Ingredients', 'get', segments: ['1'], (body, info) ->
                expect(body).to.be.ok()
                expect(info.statusCode).to.be 404
                done()

    describe 'put', ->

        record = name: 'Tomato'

        it 'should update an ingredient by id if the record was found', (done) ->
            mock =
                init: -> return
                findById: (id, callback) ->
                    callback(null, record)
                save: (params, callback) ->
                    expect(params.data.id).to.be 1
                    expect(params.data.name).to.be 'Tomato'
                    callback(null, record)

            testing.mockModel 'Couchbase.Ingredient', mock
            testing.callController 'Couchbase.Ingredients', 'put',
                segments: ['1']
                payload: record
            , (body, info) ->
                expect(body.id).to.be 1
                expect(body.name).to.be 'Tomato'
                expect(info.statusCode).to.be 200
                done()

        it 'should return 404 if the resource was not found', (done) ->
            mock =
                init: -> return
                findById: (id, callback) ->
                    callback(null, null)

            testing.mockModel 'Couchbase.Ingredient', mock
            testing.callController 'Couchbase.Ingredients', 'put',
                segments: ['1']
                payload: record
            , (body, info) ->
                expect(body).to.be.ok()
                expect(info.statusCode).to.be 404
                done()

        it 'should return 404 if the id is not valid', (done) ->
            testing.mockModel 'Couchbase.Ingredient', init: -> return
            testing.callController 'Couchbase.Ingredients', 'put',
                segments: ['not a number!']
                payload: record
            , (body, info) ->
                expect(body.error).to.be.ok()
                expect(info.statusCode).to.be 400
                done()

    describe 'post', ->

        it 'should create a new ingredient it the validation passes', (done) ->
            record =
                name: 'Tomato'
            mock =
                init: -> return
                insert: (params, callback) ->
                    expect(params.data).to.be record
                    callback(null, {})

            testing.mockModel 'Couchbase.Ingredient', mock

            testing.callController 'Couchbase.Ingredients', 'post', payload: record, (body, info) ->
                expect(body).to.be.ok()
                expect(info.statusCode).to.be 201
                done()

    describe 'delete', ->

        it 'should remove an ingredient by id if the it is supplied', (done) ->
            mock =
                init: -> return
                removeById: (params, callback) ->
                    expect(params.id).to.be '1'
                    callback(null, {})

            testing.mockModel 'Couchbase.Ingredient', mock

            testing.callController 'Couchbase.Ingredients', 'delete', segments: ['1'], (body, info) ->
                expect(body).to.be.ok()
                expect(info.statusCode).to.be 200
                done()

        it 'should all ingredients if /all is passed', (done) ->
            mock =
                init: -> return
                removeAll: (callback) ->
                    callback(null)

            testing.mockModel 'Couchbase.Ingredient', mock

            testing.callController 'Couchbase.Ingredients', 'delete', segments: ['all'], (body, info) ->
                expect(body).to.be.ok()
                expect(info.statusCode).to.be 200
                done()

