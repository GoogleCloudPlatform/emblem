let path = require('path')
let HtmlWebpackPlugin = require('html-webpack-plugin')
let CspHtmlWebpackPlugin = require('csp-html-webpack-plugin')

module.exports = {
	entry: "./src/index.js",
	module: {
		rules: [
			{
				test: /\.(js|jsx)$/,
				exclude: /node_modules/,
				use: ['babel-loader'],
			},
			{
				test: /\.css$/,
				use: ["style-loader", "css-loader"]
			},
			{
				test: /\.scss$/,
				use: [
					"style-loader",
					"css-loader",
					"sass-loader"
				]
			},
			{
				test: /\.(png|jpg|jpe?g|gif|svg)$/, use: { loader: "url-loader?limit=100000" }
			},
		]
	},
	mode: "development",
	resolve: {
		extensions: ['*', '.js', '.jsx'],
	},
	output: {
		path: path.resolve(__dirname, "dist"),
		filename: "bundle.js",
		publicPath: "/"
	},
	devServer: {
		historyApiFallback: true,
		contentBase: path.resolve(__dirname, './dist'),
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: "src/index.html"
		}),
		new CspHtmlWebpackPlugin({
			'base-uri': "'self'",
			'object-src': "'none'",
			'script-src': ["'unsafe-inline'", "'self'", "'unsafe-eval'"],
			'style-src': ["'unsafe-inline'", "'self'", "'unsafe-eval'"]
		})
	]
}
