define :pacemaker_vip_primitive, :cb_network => nil, :hostname => nil, :domain => nil, :op => nil do
  net_db = data_bag_item('crowbar', "#{params[:cb_network]}_network")
  ip_addr = net_db["allocated_by_name"]["#{params[:hostname]}.#{params[:domain]}"]["address"]

  primitive_name = "#{params[:hostname]}-vip-#{params[:cb_network]}"

  # Allow one retry, to avoid races where two nodes create the primitive at the
  # same time when it wasn't created yet (only one can obviously succeed)
  pacemaker_primitive primitive_name do
    agent "ocf:heartbeat:IPaddr2"
    params ({
      "ip" => ip_addr,
    })
    op params[:op]
    action :create
    retries 1
    retry_delay 5
  end

  # we return the primitive name so that the caller can use it as part of a
  # pacemaker group if desired
  primitive_name
end
