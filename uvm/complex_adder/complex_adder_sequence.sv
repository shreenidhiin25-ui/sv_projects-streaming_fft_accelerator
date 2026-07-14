class complex_sequence extends uvm_sqequence#(complex_transaction);
    `uvm_object_utils(complex_sequece)

    function new(string="complex_sequence");
        super.new(name);
    endfunction

    task body();
        complex_transaction tr;
        tr = complex_transaction::typr_id::create('tr);
        start_item(tr);
        assert(tr.randomize());
        finish(item(tr));
    endtask 
endclass