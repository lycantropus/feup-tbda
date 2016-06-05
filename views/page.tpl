<html>
    <head><title>{{title}}</title></head>
    <body>
         <h1>{{title}}</h1>
         <table border="1">
         %for row in content:
         <tr>
		    <td>{{row}}</td>
		  %end
		  </tr>
		%end
	</table>
    </body>
</html>