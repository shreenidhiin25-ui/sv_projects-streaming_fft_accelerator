class complex_sub_sequence extends uvm_sequence #(complex_sub_item);

`uvm_object_utils(complex_sub_sequence)

    function new(string name="complex_sub_sequence");
        super.new(name);
    endfunction

    task body();
        complex_sub_item tr;
        tr = complex_sub_item::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize());
        finish_item(tr);
    endtask