
onstart:
    shell("mail -s 'Workflow started' matteo.massidda@crs4.it < {log}")

onsuccess:
    shell("mail -s 'Workflow finished, no error' matteo.massidda@crs4.it < {log}")

onerror:
    shell("mail -s 'an error occurred' matteo.massidda@crs4.it < {log}")